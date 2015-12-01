package us.pojo.tempteller;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.ImportResource;

@SpringBootApplication
@ImportResource("temp-teller-spring.xml")
@EnableAutoConfiguration
@Configuration
public class TempTellerServer {

    public static void main(String[] args) {
        SpringApplication.run(TempTellerServer.class, args);
    }
}
