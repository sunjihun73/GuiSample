package kr.co.jihun.guisample.config;

import com.zaxxer.hikari.HikariDataSource;
import org.apache.ibatis.session.SqlSessionFactory;
import org.mybatis.spring.SqlSessionFactoryBean;
import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.ApplicationContext;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;

import javax.sql.DataSource;

/**
 * Single PostgreSQL datasource shared by both Spring AI pgvector and the MyBatis
 * mappers in {@code kr.co.jihun.guisample.mapper}.
 * <p>
 * Declaring our own {@link DataSource} bean disables Spring Boot's datasource and
 * MyBatis auto-configuration, so both must be wired explicitly here.
 */
@Configuration
@MapperScan(
        basePackages = "kr.co.jihun.guisample.mapper",
        sqlSessionFactoryRef = "sqlSessionFactory")
public class DataSourceConfig
{
    @Bean
    @Primary
    @ConfigurationProperties("spring.datasource")
    public HikariDataSource dataSource()
    {
        return new HikariDataSource();
    }

    @Bean
    public SqlSessionFactory sqlSessionFactory(
            DataSource dataSource,
            ApplicationContext applicationContext) throws Exception
    {
        SqlSessionFactoryBean factory = new SqlSessionFactoryBean();
        factory.setDataSource(dataSource);
        factory.setMapperLocations(applicationContext.getResources("classpath:mapper/**/*.xml"));
        factory.setTypeAliasesPackage("kr.co.jihun.guisample.dto");

        org.apache.ibatis.session.Configuration mybatisConfig = new org.apache.ibatis.session.Configuration();
        mybatisConfig.setMapUnderscoreToCamelCase(true);
        factory.setConfiguration(mybatisConfig);

        return factory.getObject();
    }
}