package org.sample;

import org.openjdk.jmh.annotations.*;
import org.openjdk.jmh.infra.Blackhole;
import org.openjdk.jmh.runner.Runner;
import org.openjdk.jmh.runner.RunnerException;
import org.openjdk.jmh.runner.options.Options;
import org.openjdk.jmh.runner.options.OptionsBuilder;

import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicInteger;

@BenchmarkMode(Mode.Throughput) // Mede operações por segundo
@OutputTimeUnit(TimeUnit.MILLISECONDS)
@Warmup(iterations = 3, time = 500, timeUnit = TimeUnit.MILLISECONDS)
@Measurement(iterations = 5, time = 500, timeUnit = TimeUnit.MILLISECONDS)
@Fork(1)
public class JMHSample_Threads {

    @State(Scope.Group)
    public static class CounterState {
        AtomicInteger counter = new AtomicInteger(0);
    }

    // Grupo chamado "concurrent"
    @Benchmark
    @Group("concurrent")
    @GroupThreads(4) // 4 threads executando este método dentro do grupo
    public void increment(CounterState state) {
        state.counter.incrementAndGet();
    }

    @Benchmark
    @Group("concurrent")
    @GroupThreads(2) // 2 threads executando este método dentro do grupo
    public void read(CounterState state, Blackhole bh) {
        bh.consume(state.counter.get());
    }

    public static void main(String[] args) throws RunnerException {
        Options opt = new OptionsBuilder()
                .include(JMHSample_Threads.class.getSimpleName())
                .build();

        new Runner(opt).run();
    }
}
