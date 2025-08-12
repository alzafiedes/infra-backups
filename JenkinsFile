pipeline {
  agent any
  options { timestamps() }
  stages {
    stage('Checkout') { steps { checkout scm } }
    stage('Prechecks') { steps { sh 'echo Host: $(hostname -f); git --version || true' } }
    stage('Hello') { steps { sh 'echo Jenkins listo 🎉' } }
  }
}
