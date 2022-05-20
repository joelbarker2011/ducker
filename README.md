# Ducker

A test project for Docker Swarm setup and deployment


## Local development

- Clone this repo
- Create an SSL key and certificate in `nginx/nginx.key` and `nginx/nginx/crt`
- Run `docker-compose up`
- Check out the new site on http://localhost:8080 or https://localhost:8443


## Creating images for deployment

- `docker build -t joelbarker2011/ducker .`
- `docker push joelbarker2011/ducker`


## Set up Docker Swarm

- Spin up 1 or more servers with Docker installed
- Make sure that these ports are open:
  - `22` for SSH (TCP)
  - `2377` for Docker Swarm (TCP)
  - `7946` for Docker Swarm (TCP + UDP)
  - `4789` for Docker Swarm (UDP)
  - `8080` for this Docker container (TCP)
  - `8443` for this Docker container (TCP)
  - The Docker Swarm ports should be restricted to the IPs of the servers, if possible.
- `docker swarm init --advertise-addr <server-ip>` on the manager node (pick any server as the initial manager)
- Copy the `token` from the output message
- `docker swarm join --token <token> <manager-node-ip>:2377` on all the other servers
- `docker node ls` on the manager node to verify that all the nodes are active

You should set up some additional manager nodes for redundancy. On the manager node run:
- `docker node promote <other-node-ip>`


## First deployment

- Log in to a manager node
- Copy (or regenerate) SSL key and certificate in `nginx.key` and `nginx.crt`
- Create Docker `secrets` for these files:
  - `cat nginx.key | docker secret create private-key -`
  - `cat nginx.crt | docker secret create public-crt -`
- `docker secret ls` to confirm that the `secrets` have been created
- Delete the local SSL files (keep backups in a secure location off server if needed)
- `docker swarm create --publish 8080:8080 --publish 8443:8443 --secret private-key --secret public-crt ducker joelbarker2011/ducker`

Check the number of nodes that are running this service: `docker service ps --desired-state=running ducker`

Probably there will be only 1, so scale it up to >= the number of servers: `docker service scale ducker=4`

There should now be several nodes running this service.


## Future deployments

- Log in to a manager node
- `docker pull joelbarker2011/ducker` to get the latest image
- `docker service update --image joelbarker2011/ducker ducker` to update the service to use the latest image

