package com;

import org.openjdk.jmh.annotations.*;
import org.openjdk.jmh.infra.Blackhole;
import org.openjdk.jmh.runner.Runner;
import org.openjdk.jmh.runner.options.*;
import java.util.concurrent.*;

public class Main {

    public static void main(String[] args) throws Exception {
        Options opt = new OptionsBuilder().include(Main.class.getSimpleName()).warmupIterations(0).measurementIterations(3).build();

        new Runner(opt).run();
    }

    @Benchmark
    @BenchmarkMode({Mode.SingleShotTime,Mode.AverageTime,Mode.Throughput,Mode.SampleTime})
    @OutputTimeUnit(TimeUnit.MILLISECONDS)
    @Fork(1)
    public void makeRequests(MakeRequestsState state, Blackhole blackhole) {
        state.getTest().makeRequests(state.getEndPoint());
       // System.out.println(state.getTest().handleRequest());
    }
}
