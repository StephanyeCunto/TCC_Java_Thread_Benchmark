from locust import HttpUser, task, between, constant
from locust import LoadTestShape

# Usuário que faz o GET
class LoadTest(HttpUser):
    wait_time = constant(0)  # sem delay entre requests

    @task
    def test_endpoint(self):
        self.client.get("/threads/traditional")


# Forma do teste: taxa fixa de 100.000 req/s durante 10s
class ConstantArrivalRate(LoadTestShape):
    rate = 100000       # 100k req/seg
    duration = 10       # 10 segundos

    def tick(self):
        run_time = self.get_run_time()

        if run_time < self.duration:
            return (self.rate, self.rate)  # (spawn_rate, users)
        else:
            return None
