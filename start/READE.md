```
oarsub -t deploy -l host=2,walltime=2 "kadeploy3 -a build/mutilate-environment/mutilate-environment.dsc --output-ok-nodes ~/.ok_nodes_client; \
    scp ~/.ok_nodes_client nancy:~/.ok_nodes_client; \
    sleep infinity"
```
