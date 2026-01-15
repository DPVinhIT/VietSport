using HQTCSDL_UI;
using System;
using System.Windows.Forms;

namespace MANAGER   // namespace phải trùng với namespace của Login.cs
{
    internal static class Program
    {
        [STAThread]
        static void Main()
        {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            Application.Run(new Manager());   // <<< form nào muốn chạy thì để vào đây
        }
    }
}
