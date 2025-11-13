package com.benchmark.server.controller;

import java.util.concurrent.atomic.AtomicInteger;

import org.springframework.web.bind.annotation.*;

@RestController
public class ThreadBenchmarkController {
    private static final long SLEEP_DURATION_MS = 10;
    private final AtomicInteger threadCounter = new AtomicInteger(0);

    @GetMapping("/virtualThread")
    public String startVirtualThread() {
        Thread t = Thread.ofVirtual().start(this::simulateWork);
    
        join(t);

        threadCounter.incrementAndGet();

        return "Thread virtual iniciada! Veja o console do servidor.";
    }

    @GetMapping("/traditionalThread")
    public String startTraditionalThread() {
        Thread t = new Thread(this::simulateWork);

        t.start();

        join(t);

        threadCounter.incrementAndGet();

        return "Thread iniciada! Veja o console do servidor.";
    }

    private void simulateWork(){
        try{
            Thread.sleep(SLEEP_DURATION_MS);
        }catch(InterruptedException e){
            System.out.println(e);
        }
    }

    private void join(Thread t){
        try{
            t.join();
        }catch(InterruptedException e){
            System.out.println(e);
        }
    }

    @GetMapping("/getCounter")
    public int getCounter() {
        return threadCounter.get();
    }

   @DeleteMapping("/resetCounter")
    public int resetCounter() {
        int oldValue = threadCounter.getAndSet(0); 
        return oldValue;
    }
}

