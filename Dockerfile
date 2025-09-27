# Sử dụng base image Node.js nhẹ
FROM node:20-alpine

# Thiết lập thư mục làm việc bên trong container
WORKDIR /usr/src/app

# Copy file package.json và package-lock.json (nếu có)
# để cài đặt dependencies trước
COPY package*.json ./

# Cài đặt dependencies của ứng dụng
RUN npm install

# Copy toàn bộ mã nguồn ứng dụng vào container
COPY . .

# Ứng dụng sẽ lắng nghe trên cổng 3000
EXPOSE 3000

# Lệnh mặc định để chạy ứng dụng
CMD [ "node", "server.js" ]