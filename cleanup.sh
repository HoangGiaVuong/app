#bin/bash
# Remove the network
docker network rm laptop_network

# Remove the volume
docker volume rm db_data