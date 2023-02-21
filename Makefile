.PHONY: prep start destroy 

start:
	scripts/start.sh $(name)

destroy:
	scripts/destroy.sh $(name)

prep:
	scripts/init.sh