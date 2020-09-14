#!groovy

def call(Map map) {
	pipeline {
		agent { node { label 'maven' } }

		parameters {
			string(name:'TAG_NAME',defaultValue: '',description:'')
		}

		environment {
			DOCKER_CREDENTIAL_ID = 'dockerhub-id'
			GITHUB_CREDENTIAL_ID = 'minhao-github'
			KUBECONFIG_CREDENTIAL_ID = 'demo-kubeconfig'
			REGISTRY = 'harbor.1hai.cn'
			DOCKERHUB_NAMESPACE = 'java'
			GITHUB_ACCOUNT = 'kubesphere'
			APP_NAME = 'koala'
			// SONAR_CREDENTIAL_ID = 'sonar-token'
		}

		stages {

            stage ('start') {
                echo "pipeline start "
            }


			stage ('checkout scm') {
                echo "checkout scm"
				steps {
					checkout(scm)
				}
			}

			// stage ('unit test') {
			//     steps {
			//         container ('maven') {
			//             sh 'mvn clean -o -gs `pwd`/configuration/settings.xml test'
			//         }
			//    }
			// }

			// stage('sonarqube analysis') {
			//   steps {
			//     container ('maven') {
			//       withCredentials([string(credentialsId: "$SONAR_CREDENTIAL_ID", variable: 'SONAR_TOKEN')]) {
			//         withSonarQubeEnv('sonar') {
			//         sh "mvn sonar:sonar -o -gs `pwd`/configuration/settings.xml -Dsonar.branch=$BRANCH_NAME -Dsonar.login=$SONAR_TOKEN"
			//        }
			//       }
			//      timeout(time: 1, unit: 'HOURS') {
			//         waitForQualityGate abortPipeline: true
			//      }
			//    }
			//  }
			//}

			stage ('build & push') {
				steps {
					container ('maven') {
						sh 'mvn -Dmaven.test.skip=true -gs `pwd`/settings.xml  package'
						sh 'docker build -f Dockerfile -t $REGISTRY/$DOCKERHUB_NAMESPACE/$APP_NAME:SNAPSHOT-$BRANCH_NAME-$BUILD_NUMBER .'
						withCredentials([usernamePassword(passwordVariable : 'DOCKER_PASSWORD' ,usernameVariable : 'DOCKER_USERNAME' ,credentialsId : "$DOCKER_CREDENTIAL_ID" ,)]) {
							sh 'echo "$DOCKER_PASSWORD" | docker login $REGISTRY -u "$DOCKER_USERNAME" --password-stdin'
							sh 'docker push  $REGISTRY/$DOCKERHUB_NAMESPACE/$APP_NAME:SNAPSHOT-$BRANCH_NAME-$BUILD_NUMBER'
						}
					}
				}
			}

			stage('push latest'){
				when{
					branch 'k8s-test'
				}
				steps{
					container ('maven') {
						sh 'docker tag  $REGISTRY/$DOCKERHUB_NAMESPACE/$APP_NAME:SNAPSHOT-$BRANCH_NAME-$BUILD_NUMBER $REGISTRY/$DOCKERHUB_NAMESPACE/$APP_NAME:latest '
						sh 'docker push  $REGISTRY/$DOCKERHUB_NAMESPACE/$APP_NAME:latest '
					}
				}
			}

			stage('deploy to dev') {
				when{
					branch 'k8s'
				}
				steps {
					input(id: 'deploy-to-dev', message: 'deploy to dev?')
					kubernetesDeploy(configs: 'deploy/dev/**', enableConfigSubstitution: true, kubeconfigId: "$KUBECONFIG_CREDENTIAL_ID")
				}
			}
			stage('push with tag'){
				when{
					expression{
						return params.TAG_NAME =~ /v.*/
					}
				}
				steps {
					container ('maven') {
						input(id: 'release-image-with-tag', message: 'release image with tag?')
					//	withCredentials([usernamePassword(credentialsId: "$GITHUB_CREDENTIAL_ID", passwordVariable: 'GIT_PASSWORD', usernameVariable: 'GIT_USERNAME')]) {
					//		sh 'git config --global user.email "kubesphere@yunify.com" '
					//		sh 'git config --global user.name "kubesphere" '
					//		sh 'git tag -a $TAG_NAME -m "$TAG_NAME" '
					//		sh 'git push http://$GIT_USERNAME:$GIT_PASSWORD@github.com/$GITHUB_ACCOUNT/devops-java-sample.git --tags --ipv4'
					//	}
						sh 'docker tag  $REGISTRY/$DOCKERHUB_NAMESPACE/$APP_NAME:SNAPSHOT-$BRANCH_NAME-$BUILD_NUMBER $REGISTRY/$DOCKERHUB_NAMESPACE/$APP_NAME:$TAG_NAME '
						sh 'docker push  $REGISTRY/$DOCKERHUB_NAMESPACE/$APP_NAME:$TAG_NAME '
					}
				}
			}
			stage('deploy to production') {
				when{
					expression{
						return params.TAG_NAME =~ /v.*/
					}
				}
				steps {
					input(id: 'deploy-to-production', message: 'deploy to production?')
					kubernetesDeploy(configs: 'deploy/prod/**', enableConfigSubstitution: true, kubeconfigId: "$KUBECONFIG_CREDENTIAL_ID")
				}
			}
		}
	}}