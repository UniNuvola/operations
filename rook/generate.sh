#!/bin/bash

if [ -f common.sh ]; then source common.sh ; fi
if [ -f ../common.sh ]; then source ../common.sh ; fi

SERVICES_HOST=dipcont12
TODAY=`date +%Y-%m-%d`
UNINUVOLA_DIR=/root/uninuvola

# Check k8s namespace existence
if ! kubectl get ns $NAMESPACE | grep $NAMESPACE | grep Active | wc -l | grep 1 2>&1 > /dev/null; then
  exit 1
fi

# Backup scripts

mkdir -p $OPERATIONDIR/rook/backups

# Create a backup script for each PVC
kubectl -n $NAMESPACE get pvc | tail -n +2 | cut -d ' ' -f 1 | while read PVC; do
	cat <<EOF > $OPERATIONDIR/rook/backups/backup-$PVC.sh
#!/bin/bash

TODAY=\`date +%Y-%m-%d-%H-%M-%S\`

kubectl apply -f backuppod-$PVC.yaml
kubectl apply -f backupsrv-$PVC.yaml

kubectl wait --for=condition=Ready pod/backup-$PVC --timeout=60s

kubectl -n $NAMESPACE port-forward svc/backup-$PVC-service 2222:2222 &
sleep 5

ssh -oStrictHostKeyChecking=no root@$BACKUPSERVER "zfs list | cut -f 1 -d ' '| egrep $BACKUPPOOL/$NAMESPACE/$PVC$ || zfs create $BACKUPPOOL/$NAMESPACE/$PVC"

ssh -oStrictHostKeyChecking=no -p 2222 localhost -l root "/usr/bin/rsync -e 'ssh -o StrictHostKeyChecking=no' --numeric-ids -av --delete /backup/ root@$BACKUPSERVER:$BACKUPDIR/$NAMESPACE/$PVC/"
ssh -oStrictHostKeyChecking=no root@$BACKUPSERVER "zfs snapshot $BACKUPPOOL/$NAMESPACE/$PVC@\$TODAY"

kill %1
kubectl delete -f backupsrv-$PVC.yaml
kubectl delete -f backuppod-$PVC.yaml

EOF
	chmod +x $OPERATIONDIR/rook/backups/backup-$PVC.sh

	cat <<EOF > $OPERATIONDIR/rook/backups/restore-$PVC.sh
#!/bin/bash

kubectl apply -f backuppod-$PVC.yaml
kubectl apply -f backupsrv-$PVC.yaml

kubectl wait --for=condition=Ready pod/backup-$PVC --timeout=60s

kubectl -n $NAMESPACE port-forward svc/backup-$PVC-service 2222:2222 &
sleep 5

ssh -oStrictHostKeyChecking=no -p 2222 localhost -l root "/usr/bin/rsync -e 'ssh -o StrictHostKeyChecking=no' --numeric-ids -av --delete root@$BACKUPSERVER:$BACKUPDIR/$NAMESPACE/$PVC/ /backup/"

kill %1
kubectl delete -f backupsrv-$PVC.yaml
kubectl delete -f backuppod-$PVC.yaml

EOF
	chmod +x $OPERATIONDIR/rook/backups/restore-$PVC.sh

	mustache $OPERATIONDIR/rook/backuptemplatepod.yaml > $OPERATIONDIR/rook/backups/backuppod-$PVC.yaml << EOF
Namespace: $NAMESPACE
ClaimName: $PVC
EOF
	mustache $OPERATIONDIR/rook/backuptemplatesrv.yaml > $OPERATIONDIR/rook/backups/backupsrv-$PVC.yaml << EOF
Namespace: $NAMESPACE
ClaimName: $PVC
EOF

done
