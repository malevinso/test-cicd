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
	  	 DEPLOY_CREDS = credentials('Deployment')
    	 MULE_VERSION = '4.3.0'
    	 BG = "Pandora"
    	 SECRET_KEY =  credentials('secret.key')
    	 ANYPOINT_CREDS = credentials('Anypoint-Staging')
    	 //GIT_ACCESS = credentials('6ac99e8b-beaa-4d8d-98cf-ebeb4e5cffe5')
    	 MVN = "/home/esbuild/bin/mvn"
		 gitHost = "bitbucket.savagebeast.com/scm/es/${APPNAME}.git"
		 gitURL = "https://bitbucket.savagebeast.com/scm/es/${APPNAME}.git"
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
   				   //sh "git remote set-url origin https://${GIT_ACCESS}@${gitHost}"
					//sh  "(set +e;git remote remove jenkins ; exit 0)"
					sh "whoami"
   				   sh "git remote -v"
   				   //sh "git config --global"
					//sh "git status"
   				     if ( "${BRANCH}" ==~ ~/.*${prodBranch}.*/) {
   				        //echo "user ${GIT_ACCESS_USR}" 
                         sh "${MVN} -P ${env.ENV} versions:set -DremoveSnapshot"
                         VERSION = readMavenPom().getVersion()
                         sh "git tag -a ${VERSION} -m \"Jenkins Version\"" 
                         sh "git push --tags ${APPNAME}"
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
                    sh  "git push ${APPNAME}  HEAD:${BRANCH}"
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
            	         sh "${MVN} -P ${env.ENV} clean package deploy -DmuleDeploy -Dapp.runtime=4.3.0 -Dusername=${DEPLOY_CREDS_USR} -Dpassword=${DEPLOY_CREDS_PSW} -Dcloudhub.application.name=${APPNAME} -Denvironment=${env.ENVIRONMENT} -Dregion=${REGION} -Dworkers=${WORKERS} -DworkerType=${WORKER} -DsecretKey=${SECRET_KEY_PSW}"
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