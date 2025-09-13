# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: sprodatu <sprodatu@student.42heilbronn.    +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2024/09/13 18:00:00 by sprodatu          #+#    #+#              #
#    Updated: 2024/09/13 18:00:00 by sprodatu         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

# Project configuration
NAME = inception
COMPOSE_FILE = srcs/docker-compose.yml
DATA_DIR = /home/sprodatu/data

# Colors
GREEN = \033[0;32m
YELLOW = \033[0;33m
RED = \033[0;31m
NC = \033[0m # No Color

.PHONY: all build up down stop restart clean fclean re logs status help volumes

all: up

help:
	@echo "$(GREEN)Inception - Docker Compose Project$(NC)"
	@echo ""
	@echo "Available targets:"
	@echo "  $(YELLOW)up$(NC)       - Create volumes and start all services"
	@echo "  $(YELLOW)build$(NC)    - Build all Docker images"
	@echo "  $(YELLOW)down$(NC)     - Stop and remove all containers"
	@echo "  $(YELLOW)stop$(NC)     - Stop all containers"
	@echo "  $(YELLOW)restart$(NC)  - Restart all services"
	@echo "  $(YELLOW)logs$(NC)     - Show logs from all services"
	@echo "  $(YELLOW)status$(NC)   - Show status of all containers"
	@echo "  $(YELLOW)clean$(NC)    - Remove containers and images"
	@echo "  $(YELLOW)fclean$(NC)   - Full cleanup (containers, images, volumes)"
	@echo "  $(YELLOW)re$(NC)       - Full rebuild (fclean + up)"
	@echo "  $(YELLOW)volumes$(NC)  - Create required volume directories"

volumes:
	@echo "$(GREEN)Creating volume directories...$(NC)"
	@mkdir -p $(DATA_DIR)/wordpress
	@mkdir -p $(DATA_DIR)/mariadb
	@sudo chown -R $(USER):$(USER) $(DATA_DIR)
	@echo "$(GREEN)Volume directories created successfully$(NC)"

build:
	@echo "$(GREEN)Building Docker images...$(NC)"
	@docker-compose -f $(COMPOSE_FILE) build --no-cache
	@echo "$(GREEN)Docker images built successfully$(NC)"

up: volumes
	@echo "$(GREEN)Starting Inception services...$(NC)"
	@docker-compose -f $(COMPOSE_FILE) up -d --build
	@echo "$(GREEN)Services started successfully$(NC)"
	@echo "$(YELLOW)Website available at: https://sprodatu.42.fr$(NC)"
	@echo "$(YELLOW)Add '127.0.0.1 sprodatu.42.fr' to /etc/hosts if needed$(NC)"

down:
	@echo "$(RED)Stopping all services...$(NC)"
	@docker-compose -f $(COMPOSE_FILE) down
	@echo "$(RED)Services stopped$(NC)"

stop:
	@echo "$(YELLOW)Stopping containers...$(NC)"
	@docker-compose -f $(COMPOSE_FILE) stop
	@echo "$(YELLOW)Containers stopped$(NC)"

restart:
	@echo "$(YELLOW)Restarting services...$(NC)"
	@docker-compose -f $(COMPOSE_FILE) restart
	@echo "$(GREEN)Services restarted$(NC)"

logs:
	@docker-compose -f $(COMPOSE_FILE) logs -f

status:
	@echo "$(GREEN)Container Status:$(NC)"
	@docker-compose -f $(COMPOSE_FILE) ps
	@echo ""
	@echo "$(GREEN)Network Status:$(NC)"
	@docker network ls | grep inception || echo "No inception network found"
	@echo ""
	@echo "$(GREEN)Volume Status:$(NC)"
	@docker volume ls | grep inception || echo "No inception volumes found"

clean: down
	@echo "$(RED)Cleaning up containers and images...$(NC)"
	@docker system prune -af --volumes
	@docker network prune -f
	@echo "$(RED)Cleanup completed$(NC)"

fclean: down
	@echo "$(RED)Full cleanup: removing all containers, images, and volumes...$(NC)"
	@docker system prune -af --volumes
	@docker network prune -f
	@sudo rm -rf $(DATA_DIR)/wordpress/* $(DATA_DIR)/mariadb/* 2>/dev/null || true
	@echo "$(RED)Full cleanup completed$(NC)"

re: fclean up

# Development helpers
shell-nginx:
	@docker exec -it nginx /bin/sh

shell-wordpress:
	@docker exec -it wordpress /bin/sh

shell-mariadb:
	@docker exec -it mariadb /bin/sh

# Backup and restore
backup:
	@echo "$(GREEN)Creating backup...$(NC)"
	@mkdir -p backups
	@sudo tar -czf backups/inception-backup-$(shell date +%Y%m%d-%H%M%S).tar.gz $(DATA_DIR)
	@echo "$(GREEN)Backup completed$(NC)"

# SSL certificate info
ssl-info:
	@echo "$(GREEN)SSL Certificate Information:$(NC)"
	@docker exec nginx openssl x509 -in /etc/nginx/ssl/sprodatu.42.fr.crt -text -noout | grep -A2 "Subject:"
	@docker exec nginx openssl x509 -in /etc/nginx/ssl/sprodatu.42.fr.crt -dates -noout
