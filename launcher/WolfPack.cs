using System;
using System.Diagnostics;
using System.IO;

namespace WolfPack
{
    class Program
    {
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
                System.Windows.Forms.MessageBox.Show(
                    "Could not find librewolf.exe.\n\nExpected locations:\n" +
                    string.Join("\n", searchPaths),
                    "WolfPack",
                    System.Windows.Forms.MessageBoxButtons.OK,
                    System.Windows.Forms.MessageBoxIcon.Error);
                return;
            }

            // Profile directory
            string profileDir = Path.Combine(exeDir, "Profiles", "Default");
            if (!Directory.Exists(profileDir))
                Directory.CreateDirectory(profileDir);

            // Build arguments
            string arguments = "--profile \"" + profileDir + "\" --no-remote";

            // Pass through any command-line arguments (e.g. URLs)
            if (args.Length > 0)
                arguments += " " + string.Join(" ", args);

            // Launch
            ProcessStartInfo psi = new ProcessStartInfo
            {
                FileName = lwExe,
                Arguments = arguments,
                UseShellExecute = false,
                WorkingDirectory = Path.GetDirectoryName(lwExe)
            };

            try
            {
                Process.Start(psi);
            }
            catch (Exception ex)
            {
                System.Windows.Forms.MessageBox.Show(
                    "Failed to launch WolfPack:\n" + ex.Message,
                    "WolfPack",
                    System.Windows.Forms.MessageBoxButtons.OK,
                    System.Windows.Forms.MessageBoxIcon.Error);
            }
        }
    }
}
