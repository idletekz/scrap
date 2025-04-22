parallel -j 4 \
  rsync -azvn \
    -e "ssh -i /here/sshkey.pem -o StrictHostKeyChecking=no" \
    --partial --append-verify --info=progress2 \
    "${artifact}" {}:"${dest}" \
  ::: "${hosts[@]}"

#!/usr/bin/env bash
artifact="/path/to/artifact.tar.gz"
dest="/remote/path/"
hosts=( host1 host2 host3 ... )
