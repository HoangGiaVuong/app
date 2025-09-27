// Khai báo các module cần thiết
const express = require('express');
const { Pool } = require('pg');

// Khởi tạo ứng dụng Express
const app = express();
const port = 3000;
const instanceId = process.env.INSTANCE_ID || 'UNKNOWN'; // Dùng để xác định instance đang phục vụ request

// Cấu hình kết nối PostgreSQL
const pool = new Pool({
    user: process.env.DB_USER || 'user',
    host: process.env.DB_HOST || 'db', // Tên service database trong docker-compose
    database: process.env.DB_NAME || 'laptop_store',
    password: process.env.DB_PASSWORD || 'password',
    port: 5432,
});

// Thử kết nối DB khi khởi động
pool.connect((err, client, release) => {
    if (err) {
        console.error('Lỗi kết nối đến PostgreSQL:', err.stack);
        // Có thể thoát ứng dụng nếu DB không sẵn sàng
    } else {
        console.log('Kết nối thành công đến PostgreSQL.');
        release();
    }
});

/**
 * Hàm lấy danh sách laptop từ database
 * @returns {Promise<Array>} Danh sách laptop
 */
async function getLaptops() {
    try {
        const res = await pool.query('SELECT name, price, cpu, ram FROM laptops ORDER BY id ASC');
        return res.rows;
    } catch (err) {
        console.error('Lỗi truy vấn database:', err.stack);
        return [];
    }
}

// Route chính để hiển thị danh sách sản phẩm
app.get('/products', async (req, res) => {
    const laptops = await getLaptops();

    let html = `
        <!DOCTYPE html>
        <html lang="vi">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Cửa Hàng Laptop (Load Balanced)</title>
            <script src="https://cdn.tailwindcss.com"></script>
            <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&display=swap" rel="stylesheet">
            <style>
                body { font-family: 'Inter', sans-serif; background-color: #f7f9fb; }
            </style>
        </head>
        <body class="p-4 md:p-8">
            <div class="max-w-6xl mx-auto bg-white p-6 md:p-10 rounded-xl shadow-2xl">
                <h1 class="text-3xl font-bold text-gray-800 mb-6 border-b pb-3">
                    Laptop Store - Kiến Trúc Mở Rộng
                </h1>

                <p class="mb-4 text-sm font-semibold p-2 bg-indigo-50 rounded-lg border border-indigo-200">
                    <span class="text-indigo-600">Được phục vụ bởi Instance: ${instanceId}</span>
                    (Refresh trang để thấy Load Balancer hoạt động)
                </p>

                <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
    `;

    if (laptops.length === 0) {
        html += `<p class="text-red-500 col-span-full">Không tìm thấy sản phẩm hoặc lỗi kết nối database.</p>`;
    } else {
        laptops.forEach(laptop => {
            html += `
                <div class="bg-white border border-gray-100 rounded-xl shadow-lg hover:shadow-xl transition duration-300 overflow-hidden">
                    <div class="p-5">
                        <h2 class="text-xl font-bold text-gray-900 mb-2">${laptop.name}</h2>
                        <p class="text-2xl font-extrabold text-blue-600 mb-4">${new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(laptop.price)}</p>
                        <ul class="text-sm text-gray-600 space-y-1">
                            <li><span class="font-semibold">CPU:</span> ${laptop.cpu}</li>
                            <li><span class="font-semibold">RAM:</span> ${laptop.ram}</li>
                        </ul>
                        <button class="mt-4 w-full bg-blue-500 hover:bg-blue-700 text-white font-semibold py-2 rounded-lg transition duration-150 shadow-md">
                            Mua Ngay
                        </button>
                    </div>
                </div>
            `;
        });
    }

    html += `
                </div>
            </div>
        </body>
        </html>
    `;
    res.send(html);
});

// Route kiểm tra sức khỏe của ứng dụng (dùng cho Load Balancer)
app.get('/health', (req, res) => {
    res.status(200).send({ status: 'OK', instance: instanceId });
});

app.listen(port, () => {
    console.log(`Server Node.js (Instance ${instanceId}) đang chạy trên cổng ${port}`);
});
