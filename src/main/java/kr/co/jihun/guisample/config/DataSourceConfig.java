package kr.co.jihun.guisample.config;

import com.zaxxer.hikari.HikariDataSource;
import org.apache.ibatis.session.SqlSessionFactory;
import org.mybatis.spring.SqlSessionFactoryBean;
import org.mybatis.spring.annotation.MapperScan;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.ApplicationContext;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;

import javax.sql.DataSource;

/**
 * Two-datasource setup:
 * <ul>
 *   <li><b>primary</b> — PostgreSQL, used by Spring AI pgvector and as the default {@link DataSource}.</li>
 *   <li><b>slave</b> — MySQL, used exclusively by MyBatis mappers in {@code kr.co.jihun.guisample.mapper}.</li>
 * </ul>
 * Declaring our own {@link DataSource} beans disables Spring Boot's datasource and
 * MyBatis auto-configuration, so both must be wired explicitly here.
 */
@Configuration
@MapperScan(
        basePackages = "kr.co.jihun.guisample.mapper",
        sqlSessionFactoryRef = "slaveSqlSessionFactory")
public class DataSourceConfig
{
    @Bean
    @Primary
    @ConfigurationProperties("spring.datasource")
    public HikariDataSource primaryDataSource()
    {
        return new HikariDataSource();
    }

    @Bean
    @ConfigurationProperties("slave.datasource")
    public HikariDataSource slaveDataSource()
    {
        return new HikariDataSource();
    }

    @Bean
    public SqlSessionFactory slaveSqlSessionFactory(
            @Qualifier("slaveDataSource") DataSource slaveDataSource,
            ApplicationContext applicationContext) throws Exception
    {
        SqlSessionFactoryBean factory = new SqlSessionFactoryBean();
        factory.setDataSource(slaveDataSource);
        factory.setMapperLocations(applicationContext.getResources("classpath:mapper/**/*.xml"));
        factory.setTypeAliasesPackage("kr.co.jihun.guisample.vo");

        org.apache.ibatis.session.Configuration mybatisConfig = new org.apache.ibatis.session.Configuration();
        mybatisConfig.setMapUnderscoreToCamelCase(true);
        factory.setConfiguration(mybatisConfig);

        return factory.getObject();
    }
}