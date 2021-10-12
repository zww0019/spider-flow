def app_name='spiderflow'
def deployment_name='spiderflow'
def deployment_file='deployment-26.yml'
def service_file='service-27.yml'
def img_tag="${UUID.randomUUID().toString().substring(0,5)}"
def env_tag="${UUID.randomUUID().toString().substring(0,5)}"
def git_url='https://github.com/zww0019/spider-flow.git'
podTemplate(
	inheritFrom: 'kubernetes',
	containers: [
	    containerTemplate(name: 'maven', image: 'maven:3.8-openjdk-8', ttyEnabled: true, command: 'cat', privileged: false)
	],
    label: 'gitpull'+env_tag,
    name: 'gitpull',
    nodeSelector: 'kubernetes.io/arch=amd64'
){
	node('gitpull'+env_tag) {
        stage('Get a maven project') {
            retry(3){
                git credentialsId: 'zww',url: git_url
            }
        }
    }
}
podTemplate(
	inheritFrom: 'kubernetes',
	containers: [
	    containerTemplate(name: 'maven', image: 'maven:3.8-openjdk-8', ttyEnabled: true, command: 'cat', privileged: false)
	],
    label: 'commonbuild'+env_tag,
    name: 'commonbuild'
){
	node('commonbuild'+env_tag) {
        stage('Get a maven project') {
            container('maven') {
                stage('打包') {
                    retry(3){
                        sh 'mvn clean install -f pom.xml -Dmaven.test.skip=true'
                    }
                }
            }
        }
    }
}
podTemplate(
    label: 'buildimage'+env_tag,
    inheritFrom: 'kubernetes',
	containers: [
	    containerTemplate(name: 'buildctl',image:'shopstic/buildctl:0.9.0',command: 'cat' , ttyEnabled: true, privileged: false)
	],
	envVars: [
	    envVar(key: 'app_name',value: app_name),
	    envVar(key: 'image_tag',value: img_tag)
	],
	nodeSelector: 'kubernetes.io/arch=amd64'
){
	node('buildimage'+env_tag) {
        stage('Build a Image') {
            container('buildctl'){
                stage('构建镜像'){
                retry(3){
                    sh 'buildctl \
                          --addr tcp://buildkitd:1234 \
                          build --frontend dockerfile.v0 --local context=. --local dockerfile=. --opt filename=./Dockerfile  \
                          --output type=image,name=${repo_name}/${app_name}:${image_tag},push=true'
                          }
                }
            }
        }
    }
}
podTemplate(
    label: 'deploymentpod'+env_tag,
    inheritFrom: 'kubernetes',
	containers: [
	    containerTemplate(name: 'kubectl', image: 'lachlanevenson/k8s-kubectl:latest', command: 'cat', ttyEnabled: true, privileged: false)
	],
	envVars: [
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
                    sh "sed -i 's/app_placeholder/${app_name}/' ${deployment_file}"
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
