package us.pojo.tempteller;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.ImportResource;

@SpringBootApplication
@ImportResource("weather-notifier-spring.xml")
public class WeatherNotifierApplication {

    public static void main(String[] args) {
        SpringApplication.run(WeatherNotifierApplication.class, args);
    }
}
