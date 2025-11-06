package org.sample;

import org.openjdk.jmh.annotations.*;
import java.util.concurrent.TimeUnit;

@BenchmarkMode(Mode.AverageTime)
@OutputTimeUnit(TimeUnit.MILLISECONDS)
@State(Scope.Thread)
public class TesteProfiler {

    @Benchmark
    public void test() {
        double x = 0;
        for (int i = 0; i < 10_000_000; i++) {
            x += Math.sqrt(i);
        }
    }
}
