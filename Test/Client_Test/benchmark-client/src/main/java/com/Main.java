package com;

public class Main {
    public static void main(String[] args) {
        Test t = new Test();
        long startTime = System.currentTimeMillis();
        t.makeRequests("/traditionalThread");

        long endTime = System.currentTimeMillis() - startTime;
        System.out.println("Requisições que chegaram ao servidor: "+t.handleRequest() + "\n Tempo: "+ endTime);
    }
}