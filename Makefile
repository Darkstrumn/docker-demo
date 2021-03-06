LOGDIR=logs
NUM_OF_SERVERS=100

all:
	@echo "make build -- build docker images"
	@echo "make run -- run container"
	@echo "make demo -- execute demo"
	@echo "make stop -- stop and remove all containers"

$(LOGDIR):
	@mkdir -p $@

build:
	@docker build --no-cache --force-rm -t lukaspustina/docker_demo_python python
	@docker build --no-cache --force-rm -t lukaspustina/docker_demo_webserver webserver
	@docker images

run: $(LOGDIR)
	@echo "+++ Starting containers +++"
	@for i in `seq 1 $(NUM_OF_SERVERS)`; do \
		name=webserver-$$i; \
		container_id=$$(docker run -d --cidfile=$</webserver-$$i.cid --name=$$name --hostname=$$name -v `pwd`/$<:/logs lukaspustina/docker_demo_webserver:latest /opt/webserver/run.sh /logs) ; \
		docker ps -l | tail -n +2; \
	done
	@sleep 1

demo:
	@echo "+++ Starting demo +++"
	@for i in $$(docker ps -q | xargs docker inspect -f '{{ .NetworkSettings.IPAddress }}'); do \
		curl http://$$i:8080; \
	 done


stop: $(LOGDIR)
	-@docker ps | grep lukaspustina/docker_demo_webserver | awk '{ print $$1 }' | xargs docker kill > /dev/null
	-@docker ps -a | grep lukaspustina/docker_demo_webserver | awk '{ print $$1 }' | xargs docker rm > /dev/null
	-@rm $</*.cid

clean: clean-logs clean-images

clean-logs:
	-@rm -rf $(LOGDIR)

clean-images:
	-@docker images -q | xargs docker rmi

