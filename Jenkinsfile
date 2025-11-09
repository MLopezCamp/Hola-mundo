pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-cred')  // credencial de DockerHub en Jenkins
        IMAGE_NAME = "mlopezcamp/hola-mundo"  // Nombre de la imagen en DockerHub
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/MLopezCamp/Hola-mundo.git'
            }
        }

        stage('Detect Changes') {
            steps {
                script {
                    // Obtiene el último commit del repo local
                    def currentCommit = sh(script: "git rev-parse HEAD", returnStdout: true).trim()

                    // Archivo donde se guarda el último commit desplegado
                    def commitFile = "${env.WORKSPACE}/.last_commit"

                    if (fileExists(commitFile)) {
                        def lastCommit = readFile(commitFile).trim()
                        if (currentCommit == lastCommit) {
                            echo "No hay cambios nuevos desde el último despliegue (${lastCommit})."
                            currentBuild.result = 'SUCCESS'
                            currentBuild.displayName = "Sin cambios"
                            // Detiene el pipeline aquí
                            error("No hay cambios nuevos — omitiendo despliegue.")
                        } else {
                            echo "Cambios detectados. Último commit anterior: ${lastCommit}"
                        }
                    } else {
                        echo "Primer despliegue: no existe registro previo de commit."
                    }

                    // Guarda el commit actual para la próxima ejecución
                    writeFile file: commitFile, text: currentCommit
                }
            }
        }

        stage('Generate Tag') {
            steps {
                script {
                    // Obtener ID corto del commit actual
                    def GIT_COMMIT = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()

                    // Obtener la fecha en formato YYYYMMDD-HHMMSS
                    def DATE_TAG = sh(script: "date +%Y%m%d-%H%M%S", returnStdout: true).trim()

                    // Generar el tag combinando fecha y commit
                    def VERSION_TAG = "${DATE_TAG}-${GIT_COMMIT}"

                    // Guardar la versión como variable global para usar en otros stages
                    env.VERSION_TAG = VERSION_TAG

                    echo "Versión generada: ${VERSION_TAG}"
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                    echo "=== Construyendo imagen ==="
                    docker build -t $IMAGE_NAME:$VERSION_TAG .
                    docker tag $IMAGE_NAME:$VERSION_TAG $IMAGE_NAME:latest
                '''
            }
        }

        stage('Login to DockerHub') {
            steps {
                sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
            }
        }

        stage('Push to DockerHub') {
            steps {
                sh '''
                    echo "=== Subiendo imagen a DockerHub ==="
                    docker push $IMAGE_NAME:$VERSION_TAG
                    docker push $IMAGE_NAME:latest
                '''
            }
        }
    }

    post {
        always {
            echo "=== Limpieza final ==="
            sh 'docker system prune -f || true'
        }
        success {
            echo "Pipeline completado con éxito"
            echo "Se subieron las siguientes versiones:"
            echo "-> $IMAGE_NAME:latest"
            echo "-> $IMAGE_NAME:$VERSION_TAG"
        }
        failure {
            echo "Pipeline falló"
        }
    }
}
