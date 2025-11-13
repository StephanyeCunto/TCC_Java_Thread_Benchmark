module benchmark.client {
    requires java.base;
    requires java.net.http;
    requires lombok;
    requires jmh.core;

    exports com.jmh_generated;
}
