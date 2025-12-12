echo "GET http://192.168.1.6:8080/threads/traditional" | vegeta attack -duration=60s -timeout=0s -rate=700 -max-workers=100000| tee "warmup.bin" | vegeta report --type=json > warmup.json

echo "GET http://192.168.1.6:8080/threads/traditional" | vegeta attack -duration=180s -timeout=0s -rate=6000  -max-workers=100000| tee "run.bin" | vegeta report --type=json > run.json

echo "GET http://192.168.1.6:8080/threads/traditional" | vegeta attack -duration=180s -timeout=0s -rate=6000  -max-workers=100000| tee "loop.bin" | vegeta report --type=json > loop.json
