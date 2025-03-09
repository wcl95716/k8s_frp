build:
	docker compose build


stop:
	docker compose down

run:
	docker compose up -d

stop_frps:
	systemctl stop  frps
	systemctl disable frps


push:
	git add *
	git add -u 
	git commit -m "update"
	git push origin main