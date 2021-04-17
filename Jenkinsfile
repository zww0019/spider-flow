pipeline {
    agent any
    //options { skipDefaultCheckout() }
    stages {
    	stage("构建环境设置") {
			steps{
				script {
				
					// 镜像名称
					env.IMAGE_NAME = "spiderflow"
					// 私有镜像仓库地址
					env.IMAGE_REPOSITORY = "abc.kdphoto.cn:5000"
					sh "git rev-parse --short HEAD > .git/spiderflow-commit-id"
					// 镜像版本 
					env.SHORT_COMMIT_ID = readFile file: ".git/spiderflow-commit-id" , encoding: "UTF-8"
					echo "镜像名称：${env.IMAGE_NAME}"
					echo "镜像版本：${env.SHORT_COMMIT_ID}"
					echo "私有镜像仓库地址：${env.IMAGE_REPOSITORY}"
				}
			}
		}
        stage('构建镜像') {
             options { skipDefaultCheckout() }
             steps {
                  sh 'docker build  -t  $IMAGE_REPOSITORY/$IMAGE_NAME:$SHORT_COMMIT_ID -f dockerfile/Dockerfile .'
             }
        }
        stage('上传镜像') {
             options { skipDefaultCheckout() }
             steps {
                  sh 'docker push $IMAGE_REPOSITORY/$IMAGE_NAME:$SHORT_COMMIT_ID'
             }
        }
        stage('滚动更新') {
             options { skipDefaultCheckout() }
             steps {
                  sh 'docker service update --image $IMAGE_REPOSITORY/$IMAGE_NAME:$SHORT_COMMIT_ID $IMAGE_NAME'
             }
        }
    }
}