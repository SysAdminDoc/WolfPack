using System;
using System.Diagnostics;
using System.IO;
using System.Collections.Generic;

namespace WolfPack
{
    class Program
    {
        private static void ShowError(string message)
        {
            System.Windows.Forms.MessageBox.Show(
                message,
                "WolfPack",
                System.Windows.Forms.MessageBoxButtons.OK,
                System.Windows.Forms.MessageBoxIcon.Error);
        }

        private static string QuoteArgument(string value)
        {
            if (value == null)
                return "\"\"";

            if (value.Length > 0 && value.IndexOfAny(new char[] { ' ', '\t', '\"' }) < 0)
                return value;

            return "\"" + value.Replace("\"", "\\\"") + "\"";
        }

        static void Main(string[] args)
        {
            string exeDir = Path.GetDirectoryName(
                System.Reflection.Assembly.GetExecutingAssembly().Location);

            // Find librewolf.exe relative to the launcher
            string lwExe = null;
            string[] searchPaths = new string[]
            {
                Path.Combine(exeDir, "librewolf", "librewolf.exe"),
                Path.Combine(exeDir, "LibreWolf", "librewolf.exe"),
                Path.Combine(exeDir, "librewolf.exe")
            };

            foreach (string path in searchPaths)
            {
                if (File.Exists(path))
                {
                    lwExe = path;
                    break;
                }
            }

            if (lwExe == null)
            {
                ShowError(
                    "Could not find librewolf.exe.\n\nExpected locations:\n" +
                    string.Join("\n", searchPaths));
                return;
            }

            // Profile directory
            string profileDir = Path.Combine(exeDir, "Profiles", "Default");
            int passthroughStart = 0;
            try
            {
                if (args.Length > 0 &&
                    string.Equals(args[0], "--profile-override", StringComparison.OrdinalIgnoreCase))
                {
                    if (args.Length < 2 || string.IsNullOrWhiteSpace(args[1]))
                    {
                        ShowError("--profile-override requires a profile directory path.");
                        return;
                    }

                    profileDir = Path.GetFullPath(args[1]);
                    passthroughStart = 2;
                }

                if (!Directory.Exists(profileDir))
                    Directory.CreateDirectory(profileDir);
            }
            catch (Exception ex)
            {
                ShowError("Could not prepare the WolfPack profile:\n" + ex.Message);
                return;
            }

            // Build arguments
            List<string> launchArguments = new List<string>
            {
                "--profile",
                QuoteArgument(profileDir),
                "--no-remote"
            };

            // Pass through any command-line arguments (e.g. URLs)
            for (int i = passthroughStart; i < args.Length; i++)
                launchArguments.Add(QuoteArgument(args[i]));

            // Launch
            ProcessStartInfo psi = new ProcessStartInfo
            {
                FileName = lwExe,
                Arguments = string.Join(" ", launchArguments),
                UseShellExecute = false,
                WorkingDirectory = Path.GetDirectoryName(lwExe)
            };

            try
            {
                Process.Start(psi);
            }
            catch (Exception ex)
            {
                ShowError("Failed to launch WolfPack:\n" + ex.Message);
            }
        }
    }
}
