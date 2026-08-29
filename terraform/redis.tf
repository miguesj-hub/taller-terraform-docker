resource "docker_image" "redis" {
    name = "redis:7-alpine"
}
resource "docker_container" "redis" {
    name = "manual-redis"
    image = docker_image.redis.image_id
    networks_advanced {
        name = docker_network.workshop_net.name
    }
}