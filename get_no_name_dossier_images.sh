#!/bin/bash

##非实名档案FP信息##
D_FP_IP="192.168.67.31"
#D_user="admin"
#D_passwd="admin"
##人像库检索FP信息##
R_FP_IP="192.168.0.139"
R_user="admin"
R_passwd="admin"
R_repository_id="20"
##人像库存储FP信息##
U_FP_IP="192.168.0.139"
U_user="admin"
U_passwd="admin"
U_repository_id="8"
####################
max_number="100"
####################
X=0
while [ $X -le $max_number ]
do
let Y=$X*100
curl -s --location --request POST 'http://'$D_FP_IP':11180/opod/v2/dossier_set/dossier_query' \
--header 'Content-Type: application/json' \
--data-raw '{
    "dossier_meta_conditions": {
        "dossier_type": 0
    },
    "enable_merge_realname": false,
    "limit": 100,
    "no_usi": true,
    "offset": '$Y',
    "order_by": "face_record_num_desc"
}'|jq -c '.dossiers[]|.id'|sed "s/\$/,/g"|sed '$s/.$//' > dossiers.id

echo "$Y ==>"|tee -a $(date '+%Y-%m-%d').log

record_ids=$(cat dossiers.id)
echo "{
    \"dossier_ids\": [
        '${record_ids}'
    ]
}"|sed "s/'//g" > record_ids

curl -s --location --request POST 'http://'$D_FP_IP':11180/opod/v2/dossier/meta/batch/query' --header 'Content-Type: application/json' -d@record_ids\
|jq -c '.metas[]|.attributes.cover'|sed "s/\$/,/g"|sed '$s/.$//' > cover.id
cover_id=$(cat cover.id)
echo "{
    \"record_ids\": [
        '${cover_id}'
    ]
}"|sed "s/'//g" > cover_id

curl -s --location --request POST 'http://'$D_FP_IP':11180/opod/v2/record/url' --header 'Content-Type: application/json' -d@cover_id\
|jq -cr '.results[]|del(.record_id)|del(.cluster_id)|del(.face_image_id)|del(.url_host)|del(.picture_url)|del(.record_feature_type)|.face_image_url'\
|sed 's#^#http://'$D_FP_IP':11180#g' > urls

#D_Passwd=$(echo -n $D_passwd|md5sum|awk '{print $1}')
#D_session_id=$(curl -s --location --request POST 'http://'$D_FP_IP':11180/business/api/login' \
#--header 'Content-Type: application/json' \
#--data-raw '{"name": "'$D_user'","password": "'$D_Passwd'"}'|jq -r '.session_id')

R_Passwd=$(echo -n $R_passwd|md5sum|awk '{print $1}')
R_session_id=$(curl -s --location --request POST 'http://'$R_FP_IP':11180/business/api/login' \
--header 'Content-Type: application/json' \
--data-raw '{"name": "'$R_user'","password": "'$R_Passwd'"}'|jq -r '.session_id')

i=0
while read url
do
let i++
rm -rf cache_images/*.jpg
curl -s --location --request GET $url -o cache_images/$i.jpg
image_base64=$(base64 -w 0 cache_images/$i.jpg)
echo '{"limit": 1,"order": {"similarity": -1},"retrieval": {"picture_image_content_base64": "'$image_base64'","repository_ids": ['$R_repository_id'],"threshold": 93},"start": 0}' > r_data
curl -s --location --request POST 'http://'$R_FP_IP':11180/business/api/retrieval_repository' \
--header 'session_id: '$R_session_id'' \
--header 'Content-Type: application/json' \
-d@r_data|jq -c '.'|grep "name" > cache_json/$i.json
test -s cache_json/$i.json
if [ $? == "0" ]
then
J_gender=$(jq '.results[].gender' cache_json/$i.json)
J_person_id=$(jq -r '.results[].person_id' cache_json/$i.json)
J_name=$(jq '.results[].name' cache_json/$i.json)
R_url=$(jq -r '.results[].global_face_image_uri' cache_json/$i.json|sed 's#^#http://'$R_FP_IP':11180#g')
#这里上传和查询都在139上#
R_total=$(curl -s --location --request POST 'http://'$R_FP_IP':11180/business/api/condition/query_repository' \
--header 'session_id: '$R_session_id'' \
--header 'Content-Type: application/json' \
--data-raw '{"condition": {"repository_ids": ["'$U_repository_id'"],"person_id": "'$J_person_id'"},"order": {"timestamp": -1},"start": 0,"limit": 1}'\
|jq -r '.total')
if [ $R_total == "0" ]
then
curl -s --location --request GET $R_url -o cache_images/R_$i.jpg
R_image_base64=$(base64 -w 0 cache_images/R_$i.jpg)
echo '{"images": [ {"gender": '$J_gender',"name": '$J_name',"person_id": "'$J_person_id'","picture_image_content_base64": "'$R_image_base64'","repository_id": "'$U_repository_id'"}]}' > i_data
curl -s --location --request POST 'http://'$U_FP_IP':11180/business/api/repository/picture/batch_single_person' \
--header 'Content-Type: application/json' \
--header 'session_id: '$R_session_id'' \
-d@i_data >> $(date '+%Y-%m-%d').log
echo '' > i_data
echo "$Y $i $J_name 导入实名库"|tee -a $(date '+%Y-%m-%d').log
#sleep 2
else
echo "$Y $i $J_name $J_person_id 已在实名库"|tee -a $(date '+%Y-%m-%d').log
fi
fi
done < urls

let X++
done
