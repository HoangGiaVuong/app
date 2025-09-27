-- Tạo bảng lưu trữ thông tin laptop
CREATE TABLE IF NOT EXISTS laptops (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    price INT NOT NULL,
    cpu VARCHAR(50),
    ram VARCHAR(50)
);

-- Thêm dữ liệu mẫu vào bảng
INSERT INTO laptops (name, price, cpu, ram) VALUES
('MacBook Pro M3', 45000000, 'Apple M3 Pro', '18GB'),
('Dell XPS 13 Plus', 32500000, 'Intel Core Ultra 7', '16GB'),
('HP Spectre x360', 28000000, 'Intel Core i7 13th Gen', '16GB'),
('Lenovo ThinkPad X1', 35000000, 'Intel Core i5 13th Gen', '32GB'),
('Asus ROG Strix G16', 41000000, 'Intel Core i9 14th Gen', '32GB')
ON CONFLICT (id) DO NOTHING;
