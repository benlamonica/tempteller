package us.pojo.tempteller;

import java.util.List;

import javax.servlet.Filter;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.ImportResource;
import org.springframework.context.support.PropertySourcesPlaceholderConfigurer;
import org.springframework.web.method.support.HandlerMethodArgumentResolver;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurerAdapter;

import com.google.common.base.Predicates;

import springfox.documentation.builders.PathSelectors;
import springfox.documentation.builders.RequestHandlerSelectors;
import springfox.documentation.service.ApiInfo;
import springfox.documentation.service.Contact;
import springfox.documentation.spi.DocumentationType;
import springfox.documentation.spring.web.plugins.Docket;
import springfox.documentation.swagger2.annotations.EnableSwagger2;
import us.pojo.tempteller.util.HeaderInfoResolver;
import us.pojo.tempteller.util.RequestLogger;

@SpringBootApplication
@ImportResource("temp-teller-spring.xml")
@EnableAutoConfiguration
@EnableSwagger2
@Configuration
public class TempTellerServer extends WebMvcConfigurerAdapter {

	@Bean
	public static PropertySourcesPlaceholderConfigurer propertyConfigurer() {
		return new PropertySourcesPlaceholderConfigurer();
	}
	
	@Bean
	public Filter loggerFilter() {
		return new RequestLogger();
	}
	
    public static void main(String[] args) {
        SpringApplication.run(TempTellerServer.class, args);
    }
    
    
    
    @Override
	public void addArgumentResolvers(List<HandlerMethodArgumentResolver> argumentResolvers) {
		super.addArgumentResolvers(argumentResolvers);
		argumentResolvers.add(new HeaderInfoResolver());
	}

    @Bean
    public Docket api() { 
        return new Docket(DocumentationType.SWAGGER_2) 
          .apiInfo(new ApiInfo("TempTeller API",
        	      "Restful API for scheduling weather based rules to push to iOS devices",
        	      "1.0",
        	      "For use with the TempTeller iOS app only.",
        	      new Contact("Ben La Monica", "http://pojo.us", "ben.lamonica@icloud.com"),
        	      "(c) 2016 - All Rights Reserved",
        	      ""))
          .select()                                  
          .apis(RequestHandlerSelectors.any())              
          .paths(Predicates.not(PathSelectors.regex("/error")))
          .build();                                           
    }
}
