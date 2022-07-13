//pipeline code
pipeline {
    agent any
    stages {
        stage('Networking Configuration') {
            steps {
                sh 'docker network ls'
            }
        }
        stage('Install Dependencies') {
            steps {
                sh 'cd $WORKSPACE'
                sh 'rm -rf project'
                git branch: "master",
                    url: "https://github.com/RaziAbbas1/Devsecops.git"
                sh 'ls'
            }
        }
        stage('Pre-Build Tests') {
            parallel {
                stage('Git Repository Scanner') {
                    steps {
                        sh 'cd $WORKSPACE'
                        sh 'trufflehog https://github.com/RaziAbbas1/Devsecops --json | jq "{branch:.branch, commitHash:.commitHash, path:.path, stringsFound:.stringsFound}" > trufflehog_report.json || true'
                        sh 'cat trufflehog_report.json'
                        sh 'echo "Scanning Repositories.....done"'
                        archiveArtifacts artifacts: 'trufflehog_report.json', onlyIfSuccessful: true                      
          //              emailext attachLog: true, attachmentsPattern: 'trufflehog_report.json',
         //               body: "${currentBuild.currentResult}: Job ${env.JOB_NAME} build ${env.BUILD_NUMBER}\n More info at: ${env.BUILD_URL}\n Thankyou,\n CDAC-Project Group-7", 
         //               subject: "Jenkins Build ${currentBuild.currentResult}: Job ${env.JOB_NAME} - success", mimeType: 'text/html', to: "raziabbarizvi75@gmail.com"
                    }
                }
                stage('Image Security') {
                    steps {
                        sh 'cd $WORKSPACE'
                        sh 'dockle --input ~/docker_img_backup/mytomcat.tar -f json -o mytomcat_report.json'
                        sh 'cat mytomcat_report.json | jq {summary}'
                        sh 'dockle --input ~/docker_img_backup/pgadmin4.tar -f json -o pgadmin4_report.json'
                        sh 'cat pgadmin4_report.json | jq {summary}'
                        sh 'dockle --input ~/docker_img_backup/postgres11.tar -f json -o postgres11_report.json'
                        sh 'cat postgres11_report.json | jq {summary}'
                        sh 'dockle --input ~/docker_img_backup/zap2docker.tar -f json -o zap2docker-stable_report.json'
                        sh 'cat zap2docker-stable_report.json | jq {summary}'
                        sh 'dockle --input ~/docker_img_backup/sonarqube.tar -f json -o sonarqube_report.json'
                        sh 'cat sonarqube_report.json | jq {summary}'
                        archiveArtifacts artifacts: '*.json', onlyIfSuccessful: true
      //                  emailext attachLog: true, attachmentsPattern: '*.json', 
     //                   body: "${currentBuild.currentResult}: Job ${env.JOB_NAME} build ${env.BUILD_NUMBER}\n More info at: ${env.BUILD_URL}\n Please Find Attachments for the following:\n Thankyou\n CDAC-Project Group-7",
     //                   subject: "${env.JOB_NAME} - Build # ${env.BUILD_NUMBER} - success", mimeType: 'text/html', to: "abbyvishnoi@gmail.com"
                    }
                }
            }
        }
        stage('Build Stage') {
            steps {
                sh 'mvn clean'
                sh 'mvn compile'
                sh 'mvn package'
            }
        }
       
        stage('SCA') {
            parallel {
                stage('Dependency Check') {
                    steps {
                        sh 'wget https://github.com/RaziAbbas1/Devsecops/blob/master/dc.sh'
                        sh 'chmod +x dc.sh'
                        sh './dc.sh'
                        archiveArtifacts artifacts: 'odc-reports/*.html', onlyIfSuccessful: true
                        archiveArtifacts artifacts: 'odc-reports/*.csv', onlyIfSuccessful: true
                        archiveArtifacts artifacts: 'odc-reports/*.json', onlyIfSuccessful: true
     //                   emailext attachLog: true, attachmentsPattern: '*.html', 
     //                   body: "${currentBuild.currentResult}: Job ${env.JOB_NAME} build ${env.BUILD_NUMBER}\n More info at: ${env.BUILD_URL}\n Please Find Attachments for the following:\n Thankyou\n CDAC-Project Group-7",
     //                   subject: "${env.JOB_NAME} - Build # ${env.BUILD_NUMBER} - success", mimeType: 'text/html', to: "abbyvishnoi@gmail.com"
                    }
                }
                stage('Junit Testing') {
                    steps {
                        sh 'echo "Junit Reports are created using archiveArtifacts"'
                        archiveArtifacts artifacts: '*junit.xml', onlyIfSuccessful: true
                   //     emailext attachLog: true, attachmentsPattern: '*junit.xml', 
                    //    body: "${currentBuild.currentResult}: Job ${env.JOB_NAME} build ${env.BUILD_NUMBER}\n More info at: ${env.BUILD_URL}\n Please Find Attachments for the following:\n Thankyou\n CDAC-Project Group-7",
                   //     subject: "${env.JOB_NAME} - Build # ${env.BUILD_NUMBER} - success", mimeType: 'text/html', to: "abbyvishnoi@gmail.com"
                    }
                }
            }
        }
       //  stage('SonarQube Analysis') {
       //     steps {
       //         sh 'mvn sonar:sonar -Dsonar.projectKey=mayur -Dsonar.host.url=http://192.168.96.135:4444 -Dsonar.login=8b23a5d0adfaffdf6030607be0309be62f521981 || true'
      //      }
     //   }
        
               stage('Build Docker Images') {
                     steps {
                         sh 'docker build -t $JOB_NAME:v1.$BUILD_ID .'
                          sh 'docker image tag $JOB_NAME:v1.$BUILD_ID raziabbas1996/$JOB_NAME:v1.$BUILD_ID'
                          sh 'docker image tag $JOB_NAME:v1.$BUILD_ID raziabbas1996/$JOB_NAME:latest'
                  
              }
        }
       stage('Push Image To Docker Hub') { 
             steps {
                           withCredentials([string(credentialsId: 'dockerhubpassword', variable: 'dockerhubpassword')]) {
                           sh 'docker login -u raziabbas1996 -p ${dockerhubpassword}'
               }
                           sh 'docker image push raziabbas1996/$JOB_NAME:v1.$BUILD_ID'
                           sh 'docker image push raziabbas1996/$JOB_NAME:latest'
                           sh 'docker rmi $JOB_NAME:v1.$BUILD_ID raziabbas1996/$JOB_NAME:v1.$BUILD_ID raziabbas1996/$JOB_NAME:latest'
                   }
               }    
            stage('Deploying Containers') {
                 def dockerrun = 'docker run -p 8080:8080 -d --name Devsecops raziabbas1996/$JOB_NAME:latest'                                              
                       sshagent(['dockerhostpassword']) {                     
                           sh 'ssh -o StringHostKeyChecking=no ec2-user@172.31.3.168 ${dockerrun}'
                  }
                }   
            }
       }
     
