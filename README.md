# Kernel bypass NIC Grid5000 deployment

## Foreward

Every scripts are executed `bash -x` so that in case something unexpected happen you can easily debbug

## `~/.ssh/config`

```
Host lille rennes nantes bordeaux toulouse sophia grenoble lyon nancy strasbourg luxembourg louvain
        User <grid5000_user>
        ProxyJump <grid5000_user>@access.grid5000.fr
```

## Build environment

There 2 yaml file that are used by [kameleon](https://www.grid5000.fr/w/Environment_creation#Creating_an_environment_from_a_recipe_using_kameleon)

- `mutilate-environment.yaml`: Client environment having `mutilate` for stresstesting the host
- `environment.yaml`: Host environment where everything is installed for f-stack, caladan

```
bash -x setup_grid5000_env.sh <site> <environment|mutilate-environment>
```

Note:

- Build script use `ssh -tt` so if it crash you won't have access to the terminal, you will have to restart.
- `environment.yaml` is suggested to be built on `nancy` site because it contains Mellanox NICs (check the list [here](https://www.grid5000.fr/w/Hardware#Networking))

## Memcached clients

Whatever site you want, the moment that mutilate-environment has been built

```
ssh <grid5000_client_host>
oarsub -t deploy -l host=8,walltime=4 "kadeploy3 -a build/mutilate-environment/mutilate-environment.dsc --output-ok-nodes ~/.ok_nodes_client; \
    scp ~/.ok_nodes_client <grid5000_site_host>:~/.ok_nodes_client; \
    sleep infinity"
```

After the deployement it will transfer the list of host names so that the host can configure ssh connections.

## Host

```
ssh <grid5000_site_host>
oarsub -I -t deploy -t destructive -l slash_22=1+host=1,walltime=3
bash -x public/dont-throw-the-stack/start/start_host.sh <caladan|fstack>
ssh root@NAMEOFHOST
cd /home/work/
```

`start_host.sh` will deploy the `environment.yaml` built and additional step will be done (you can check those step directly in the script) when you will hit `sleep infinity` you can safely hit `CTRL + C`

Note: `sleep infinity` at the end of `start_host.sh` is a hack if you want to directly run the script with `oarsub -S public/dont-throw-the-stack/start/start_host.sh` (you can't pass argument and the default value will be fstack, you can change it by hands)
