def app_name='spiderflow'
def deployment_name='spiderflow'
def deployment_file='deployment-26.yml'
def service_file='service-27.yml'
def img_tag="20211125061009"
def repo_name="xiemu"
def image_name="spiderflow"
def env_tag="${UUID.randomUUID().toString().substring(0,5)}"


podTemplate(
    label: 'deploymentpod'+env_tag,
    inheritFrom: 'kubernetes',
	containers: [
	    containerTemplate(name: 'kubectl', image: 'lachlanevenson/k8s-kubectl:latest', command: 'cat', ttyEnabled: true, privileged: false)
	],
	envVars: [
		envVar(key: 'repo_name',value: repo_name),
	    envVar(key: 'app_name',value: app_name),
	    envVar(key: 'deployment_file',value: deployment_file),
	    envVar(key: 'deployment_name',value: deployment_name),
	    envVar(key: 'service_file',value: service_file),
	    envVar(key: 'image_tag',value: img_tag)
	],
	volumes: [
            persistentVolumeClaim(claimName: 'pvc-nfs-other-provisioner-nfs-subdir-external-provisioner',mountPath: '/mnt'),
        ]
){
	node('deploymentpod'+env_tag) {
        stage('Deploy') {
            container('kubectl'){
                stage('run'){
                    // 复制deployment文件到当前目录
                    sh "cp /mnt/k8s/${deployment_file} ./"
                    sh "cp /mnt/k8s/${service_file} ./"

                    sh "sed -i 's/repo_placeholder/${repo_name}/' ${deployment_file}"
                    sh "sed -i 's/app_placeholder/${image_name}/' ${deployment_file}"
                    sh "sed -i 's/tag_placeholder/${image_tag}/' ${deployment_file}"
                    sh 'kubectl apply -f ${deployment_file}'
                    sh 'kubectl apply -f ${service_file}'
                }
                stage('verification'){
                    sh 'kubectl rollout status -n default deployment ${deployment_name}'
                }
            }
        }
    }
}
