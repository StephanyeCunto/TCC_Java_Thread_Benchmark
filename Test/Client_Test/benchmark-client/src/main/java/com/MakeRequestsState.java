package com;

import org.openjdk.jmh.annotations.*;
import lombok.Getter;

@Getter
@State(Scope.Benchmark)
public class MakeRequestsState {
    private Test test = new Test();
    
    @Param({"/traditionalThread", "/virtualThread"})
    private String endPoint;
}