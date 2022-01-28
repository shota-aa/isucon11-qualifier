WEBHOOK_URL = "https://discordapp.com/api/webhooks/932996212699840553/YjmYpnNlaafG4bLN3vrU71NkjKSAg-orwD9iYSg0YxitnWYATegr2QCWDoPoYYu9Q6OG"

# ビルドして、サービスのリスタートを行う
# リスタートを行わないと反映されないので注意
.PHONY: build
build:
	cd /home/isucon/webapp/go; \
	go build -o isucondition main.go auth.go isu.go; \
	sudo systemctl restart isucondition.go.service;

.PHONY: send-pprof
send-pprof:
	go tool pprof -png -output /home/isucon/temp/profile.png http://localhost:6060/debug/pprof/profile?seconds=30
	curl -X POST -F img=@/home/isucon/temp/profile.png $(WEBHOOK_URL)