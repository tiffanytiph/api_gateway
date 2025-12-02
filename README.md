Run this docker-compose.yml in the parent folder
(copy paste code below)

```yaml
version: "3.9"

services:
  service-registry:
    build:
      context: ./service_registry
      dockerfile: Dockerfile
    container_name: service-registry
    ports:
      - "8761:8761"
    environment:
      - APP_VERSION=docker
      - EUREKA_URL=http://service-registry:8761/eureka/
    networks:
      - backend

  postgres:
    image: postgres:16.4-alpine
    container_name: quiz-postgres
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
    ports:
      - "5431:5432"
    volumes:
      - ./postgres-init:/docker-entrypoint-initdb.d
    networks:
      - backend

  question-service:
    build:
      context: ./question_service
      dockerfile: Dockerfile
    container_name: question-service
    ports:
      - "8080:8080"
    depends_on:
      - service-registry
      - postgres
    environment:
      - APP_VERSION=docker
      - EUREKA_URL=http://service-registry:8761/eureka/
      - POSTGRES_USER=postgres
      - POSTGRES_PASS=postgres
      - POSTGRES_URL=jdbc:postgresql://quiz-postgres:5432/question_db
    networks:
      - backend

  quiz-service:
    build:
      context: ./quiz_service
      dockerfile: Dockerfile
    container_name: quiz-service
    ports:
      - "8081:8081"
    depends_on:
      - service-registry
      - postgres
    environment:
      - APP_VERSION=docker
      - EUREKA_URL=http://service-registry:8761/eureka/
      - POSTGRES_USER=postgres
      - POSTGRES_PASS=postgres
      - POSTGRES_URL=jdbc:postgresql://quiz-postgres:5432/quiz_db
    networks:
      - backend
  
  api-gateway:
    build:
      context: ./api_gateway
      dockerfile: Dockerfile
    container_name: api-gateway
    ports:
      - "8090:8090"
    depends_on:
      - service-registry
    environment:
      - APP_VERSION=docker
      - EUREKA_URL=http://service-registry:8761/eureka/
    networks:
      - backend

networks:
  backend:
    driver: bridge
