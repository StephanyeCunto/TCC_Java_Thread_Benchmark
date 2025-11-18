package com.benchmark.server.controller;

import java.util.concurrent.atomic.*;

import org.springframework.web.bind.annotation.*;
import org.springframework.http.ResponseEntity;

@RestController
@RequestMapping("/threads")
public class ThreadBenchmarkController {
    private static final long SLEEP_DURATION_MS = 100;
    private final AtomicInteger threadCounter = new AtomicInteger(0);

    @GetMapping("/virtual")
    public ResponseEntity<String> startVirtualThread() {
        return createAndRunThread(Thread.ofVirtual()::unstarted, "Thread virtual criada com sucesso");
    }

    @GetMapping("/traditional")
    public ResponseEntity<String> startTraditionalThread() {
        return createAndRunThread(Thread::new, "Thread tradicional criada com sucesso");
    }

    private ResponseEntity<String> createAndRunThread(java.util.function.Function<Runnable, Thread> threadFactory,String successMessage) {
        AtomicBoolean workResult = new AtomicBoolean(false);

        Runnable task = () -> workResult.set(simulateWork());
        Thread t = threadFactory.apply(task);
        t.start();

        if (!join(t)) return ResponseEntity.status(500).body("Erro ao aguardar thread");

        if (!workResult.get()) return ResponseEntity.status(501).body("Erro ao executar trabalho");
        
        threadCounter.incrementAndGet();

        return ResponseEntity.status(201).body(successMessage);
    }

    private boolean simulateWork(){
        try{
            Thread.sleep(SLEEP_DURATION_MS);
            return true;
        }catch(InterruptedException e){
            Thread.currentThread().interrupt();
            return false;
        }
    }

    private boolean join(Thread t){
        try{
            t.join();
        }catch(InterruptedException e){
            Thread.currentThread().interrupt();
            return false;
        }
        return true;
    }

    @GetMapping("/get")
    public ResponseEntity<String> getThreadCounter(){
        int old = threadCounter.getAndSet(0);
        return ResponseEntity.status(201).body("Threads contadas: "+old);
    }

    @GetMapping("/gc")
    public void gc(){
        System.gc();
    }
}

