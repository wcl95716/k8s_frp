build:
	docker compose build


stop:
	docker compose down

run:
	docker compose up -d

stop_frps:
	systemctl stop  frps
	systemctl disable frps