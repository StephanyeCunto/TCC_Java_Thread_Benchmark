import http from "k6/http";

export const options = {
  scenarios: {
    high_load: {
      executor: "constant-arrival-rate",
      rate: 5000,            // 20k RPS
      timeUnit: "1s",
      duration: "1s",
      preAllocatedVUs: 500,
      maxVUs: 100000,
    },
  },
};

export default function () {
  http.get("http://localhost:8080/threads/virtual");
}
