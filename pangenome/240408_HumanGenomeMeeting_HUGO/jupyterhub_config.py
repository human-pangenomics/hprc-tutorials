import shutil
import os

# Configuration file for jupyterhub-demo
c = get_config()

# Use DummyAuthenticator and SimpleSpawner
c.JupyterHub.spawner_class = "simple"
c.JupyterHub.authenticator_class = "dummy"

c.DummyAuthenticator.password = "hugo24pangenome"

c.DummyAuthenticator.admin_users = {"inst_admin"}

# try to init the workspace with some files
def init_working_directory(spawner):
    usern = spawner.user.name
    os.mkdir('/tmp/' + usern)
    # copy all the files in /data
    for filen in os.listdir('/data'):
        if filen == '.ipynb_checkpoints':
            continue
        if os.path.isdir('/data/' + filen):
            shutil.copytree('/data/' + filen, '/tmp/' + usern + '/' + filen)
        else:
            shutil.copy('/data/' + filen, '/tmp/' + usern + '/' + filen)
    # symlink all the files in /bigdata
    os.mkdir('/tmp/' + usern + '/data')
    if os.path.isdir('/bigdata'):
        for filen in os.listdir('/bigdata'):
            if not os.path.isdir('/bigdata/' + filen):
                os.symlink('/bigdata/' + filen,
                           '/tmp/' + usern + '/data/' + filen)

c.Spawner.pre_spawn_hook = init_working_directory
