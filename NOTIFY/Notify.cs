using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace MANAGER
{
    public partial class Notify : Form
    {
        public Notify()
        {
            InitializeComponent();
        }

        private void Notify_Load(object sender, EventArgs e)
        {
            var dgv = dgvNotify;   // đổi theo tên DataGridView của bạn

            // Header
            dgv.EnableHeadersVisualStyles = false;
            dgv.ColumnHeadersDefaultCellStyle.BackColor = Color.ForestGreen;
            dgv.ColumnHeadersDefaultCellStyle.ForeColor = Color.White;
            dgv.ColumnHeadersDefaultCellStyle.Font = new Font("Segoe UI", 10, FontStyle.Bold);
            dgv.ColumnHeadersHeight = 35;

            // Dòng xen kẽ
            dgv.AlternatingRowsDefaultCellStyle.BackColor = Color.FromArgb(240, 255, 240);
            dgv.RowTemplate.Height = 32;

            // Màu khi chọn
            dgv.DefaultCellStyle.SelectionBackColor = Color.DarkGreen;
            dgv.DefaultCellStyle.SelectionForeColor = Color.White;

            // Style viền
            dgv.BorderStyle = BorderStyle.None;
            dgv.CellBorderStyle = DataGridViewCellBorderStyle.SingleHorizontal;
            dgv.GridColor = Color.LightGray;
            dgv.RowHeadersVisible = false;

            //
            dgv.Columns["CSTT"].DefaultCellStyle.Alignment = DataGridViewContentAlignment.MiddleCenter;
            dgv.Columns["CNotifyDate"].DefaultCellStyle.Alignment = DataGridViewContentAlignment.MiddleCenter;
            dgv.Columns["CContent"].DefaultCellStyle.Alignment = DataGridViewContentAlignment.MiddleLeft;
        }

        private void label5_Click(object sender, EventArgs e)
        {

        }

        private void label3_Click(object sender, EventArgs e)
        {

        }

        private void dgvNotify_Scroll(object sender, ScrollEventArgs e)
        {
            // để trống cũng được
        }
    }
}

       