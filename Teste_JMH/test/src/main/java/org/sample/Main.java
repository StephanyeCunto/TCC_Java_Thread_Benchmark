package org.sample;

import org.openjdk.jmh.runner.Runner;
import org.openjdk.jmh.runner.options.Options;
import org.openjdk.jmh.runner.options.OptionsBuilder;

public class Main {
    public static void main(String[] args) throws Exception {
        Options opt = new OptionsBuilder()
                .include("BlackholeConsecutiveBench") // nome da classe do benchmark
                .forks(1)                  // número de processos separados para rodar
                .build();

        new Runner(opt).run();
    }
}
