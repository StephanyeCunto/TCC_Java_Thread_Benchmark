package com;

import java.net.URI;
import java.net.http.*;

import java.io.IOException; 


public class Test {
    static final String SERVER_URL = "http://localhost:8080";
    static final int REQUEST_COUNT = 30;
    static final HttpClient client = HttpClient.newHttpClient();

    public void makeRequests(String endPoint){
        Thread[] threads = new Thread[REQUEST_COUNT];

        for(int i = 0; i < REQUEST_COUNT; i++) {
            threads[i] = new Thread(() -> {
                HttpRequest request = HttpRequest.newBuilder().uri(URI.create(SERVER_URL + endPoint)).GET().build();
                response(request);
            });
            threads[i].start();
        }

        for(int i = 0; i < REQUEST_COUNT; i++) join(threads[i]);
    } 

    private String response(HttpRequest request){
        try{
            HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());
            return response.body();
        }catch(IOException | InterruptedException e){
            System.out.println(e);
            return "Erro";
        }
    }

    private void join(Thread t){
        try{
            t.join();
        }catch(InterruptedException e){
            System.out.println(e);
        }
    }

    public int handleRequest(){
        HttpRequest request = HttpRequest.newBuilder().uri(URI.create(SERVER_URL + "/resetCounter")).DELETE().build();
        return Integer.parseInt(response(request));
    };
} 
