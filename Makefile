name = inception

all:
	@printf "Launch configuration ${name}...\n"
	@mkdir -p /home/hpehliva/data/wordpress
	@mkdir -p /home/hpehliva/data/mariadb
	@docker compose -f ./srcs/docker-compose.yml --env-file srcs/.env up -d --build

down:
	@printf "Stopping configuration ${name}...\n"
	@docker compose -f ./srcs/docker-compose.yml --env-file srcs/.env down

re: down all

clean: down
	@printf "Cleaning configuration ${name}...\n"
	@docker system prune -a

fclean:clean
	@printf "Total clean of all configurations docker\n"
	@sudo rm -rf /home/hpehliva/data/wordpress/*
	@sudo rm -rf /home/hpehliva/data/mariadb/*
	@docker system prune --all --force --volumes
	@docker network prune --force
	@docker volume prune --force

.PHONY: all down re clean fclean

