(
    export APP_VERSION=local

    sudo mvn install -Dmaven.test.skip=true

    mvn spring-boot:run -e
)