pipeline {
    agent any 
	environment {
		 APPNAME = "test-cicd"
		 WORKER = "Micro"
		 WORKERS = "1"
		 REGION = "us-west-1"
	  	 devBranch = "develop"  
	  	 prodBranch = "master"      
	  	 stgBranch = "develop"   
	  	 // DEPLOY_CREDS = credentials('Deployment')
    	 MULE_VERSION = '4.3.0'
    	 BG = "Pandora"
    	 GIT_ACCESS = credentials('github')
    	 // SECRET_KEY =  credentials('secret.key')
    	 ANYPOINT_CREDS = credentials('Anypoint-Staging')
    	 MVN = "mvn"
		 gitHost = "github.com/malevinso/${APPNAME}.git"
		 gitURL = "https://github.com/malevinso/${APPNAME}.git"
	}
    stages {
       stage('Set Build Name') {
            steps {
                script {
                    echo "GIT_BRANCH: ${env.GIT_BRANCH}"
                	setEnvironmentVars(params.EnvironmentParam,params.BranchParam)
                    currentBuild.displayName = "#${env.BUILD_NUMBER} - ${env.ENV} - ${BRANCH}"
                }
            }
    	}
     //  stage('Checkout') {
      //      steps {
      //           script {
     //               cleanWs()
     //               sh "git config --global credential.helper 'cache --timeout 7200'"
   	//			    checkout([$class: 'GitSCM', 
   	//			    		  branches: [[name: "*/${BRANCH}"]], 
   	//			    		  doGenerateSubmoduleConfigurations: false, 
   	//			    		  extensions: [], 
   	//			    		  submoduleCfg: [], 
   	//			    		  userRemoteConfigs: [[credentialsId: '8c93a098-a9db-4971-8926-355bb1b82c24', 
   	//			    		  url: "${gitURL}"]]])
    //             }
    //        }
    //   }
        stage('Build and Test all') {
            steps {
              script {
            	  //setEnvironmentVars(params.EnvironmentParam,params.BranchParam)
                  echo 'Building ' + env.GIT_BRANCH;
                  setEnvironmentVars(params.EnvironmentParam,params.BranchParam);
                  sh "${MVN} -P ${env.ENV} -DskipMunitTests clean package";
                } 
            }
        }
         stage('Version and Tag') {
         when  {
             		anyOf {
            			//triggeredBy cause: "UserIdCause"
                		expression{
                    		return "${BRANCH}" ==~ ~/.*${stgBranch}.*/  		}
                    	expression{
                    		return "${BRANCH}" ==~ ~/.*${prodBranch}.*/   		}
                }
             }
            steps {
                script {
                    VERSION = readMavenPom().getVersion()
   				    echo "Old Project Version Test: ${VERSION}";
   				    echo "Branch is ${BRANCH}";
					//sh "git checkout ${BRANCH}"
   				   //sh "git remote set-url ${APPNAME} https://${GIT_ACCESS}@${gitHost}"
   				   sh "git remote set-url origin https://${GIT_ACCESS}@${gitHost}"
					//sh  "(set +e;git remote set-url origin git@github.com:malevinso/test-cicd.git; exit 0)"
					//sh "whoami"
   				   sh "git remote -v"
   				   //sh "git config --global -l"
					//sh "git status"
   				     if ( "${BRANCH}" ==~ ~/.*${prodBranch}.*/) {
   				        //echo "user ${GIT_ACCESS_USR}" 
                         sh "${MVN} -P ${env.ENV} versions:set -DremoveSnapshot"
                         VERSION = readMavenPom().getVersion()
                         sh "(set +e;git tag -a ${VERSION} -m \"Jenkins Version\"; exit 0)" 
                         sh "(set +e;git push --tags origin; exit 0)"
                    }  else 
                    {
                       echo "Not Prod Branch, just updating snapshot version."
                       //sh "git checkout ${BRANCH}"
   				       sh "${MVN} -P ${env.ENV} build-helper:parse-version versions:set -DnewVersion=\\\${parsedVersion.majorVersion}.\\\${parsedVersion.minorVersion}.\\\${parsedVersion.nextIncrementalVersion}-SNAPSHOT versions:commit "
        			   VERSION = readMavenPom().getVersion()
                    }
   				    echo "New Project Version: ${VERSION}";
   					//sh "git checkout ${BRANCH}"
                    sh "git add -A ."
                    sh "git commit -m \"updated version ${VERSION}\""
                    sh  "(set +e;git push origin  HEAD:${BRANCH};exit 0)"
            }
          }
        }
        stage('Deploy to Binary Repo') {
            when {
            	anyOf {
            			expression { "${BRANCH}" == "${prodBranch}" };
            			expression { "${BRANCH}" == "${stgBranch}" }
           		}  
            }
            steps { 
            		echo 'Deploy to Binary Repo ' + "${stgBranch}"
            		//setEnvironmentVars(params.EnvironmentParam,params.BranchParam)
	                //  sh "${MVN} -DskipMunitTests deploy"
	              }   
          }    
          stage('Deploy to CloudHub') { 
             when  {
             		anyOf {
            			triggeredBy cause: "UserIdCause"
                		expression{
                    		return "${BRANCH}" == "${stgBranch}"
                		}
                }
             }
            steps {
            		echo 'Deploy to Anypoint'
            		script {
            		//setEnvironmentVars(params.EnvironmentParam,params.BranchParam)
            		sh "(set +x; . ./get-secret-properties.sh)"
						echo "Username: ${ANYPOINT_USERNAME:-stuff}"
            	        #echo " ${MVN} -P ${env.ENV} clean package deploy -DmuleDeploy -Dapp.runtime=${MULE_VERSION} -Dusername=${DEPLOY_CREDS_USR} -Dpassword=${DEPLOY_CREDS_PSW} -Dcloudhub.application.name=${APPNAME} -Denvironment=${env.ENVIRONMENT} -Dregion=${REGION} -Dworkers=${WORKERS} -DworkerType=${WORKER} -DsecretKey=${SECRET_KEY}"
            		}
            }
         }
     } 
}
void setEnvironmentVars(String envParam, String branchParam) {
               //echo "DEBUG: envParam=$envParam"
               //echo "DEBUG: branchParam=$branchParam"
 				if ( envParam != null){
            		      env.ENVIRONMENT = envParam
            		      if (env.ENVIRONMENT == "Production") {
            		      	env.ENV = "prod"
            		      } 
            		      else if (env.ENVIRONMENT == "Staging") {
            		      	env.ENV = "stg"
            		      }  else  {
            		      	env.ENV = "dev"
            		      } 
            	} else {
            			 env.ENVIRONMENT = "Staging"
            			 env.ENV = "stg"
            	}
            	if (branchParam != null) {
                      echo "DEBUG - NOT NULL: branchParam=$branchParam"
                    	BRANCH=branchParam
            		}
            	else {
            		     BRANCH= env.GIT_BRANCH
            	}
            		String[] gitOrigin = BRANCH.split("/");
            		BRANCH= gitOrigin[gitOrigin.length -1];
            		echo "DEBUG: setEnvironment: ENVIRONMENT: ${env.ENVIRONMENT}"
            		echo "DEBUG: setEnvironment: ENV: env=${env.ENV}"
            		echo "DEBUG: setEnvironment: BRANCH: ${BRANCH}"
}