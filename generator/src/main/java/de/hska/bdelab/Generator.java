package de.hska.bdelab;

import java.util.Date;
import java.util.UUID;
import java.util.concurrent.ThreadLocalRandom;

import org.springframework.cloud.stream.annotation.EnableBinding;
import org.springframework.cloud.stream.messaging.Source;
import org.springframework.integration.annotation.InboundChannelAdapter;
import org.springframework.integration.annotation.Poller;

@EnableBinding(Source.class)
public class Generator {


	public Generator(){

	}
	
	@InboundChannelAdapter(value = Source.OUTPUT, poller = @Poller(fixedDelay = "1000", maxMessagesPerPoll = "1"))
	public String pageviewMessageSource()  {		
		return (GenerateTimestamp() + "," + GenerateIp() + "," + GenerateUri() + "," + GenerateUid());
	}
	
	/*
	@Bean
	@InboundChannelAdapter(value = Source.OUTPUT, poller = @Poller(fixedDelay = "5000", maxMessagesPerPoll = "1"))
	public MessageSource<String> pageviewMessageSource()  {
		// create ViewObject with "randomvalues"
		ViewObject vo = new ViewObject(GenerateTimestamp(),
				GenerateIp(),
				GenerateUri(),
				GenerateUid());
		
		return() -> new GenericMessage<String>(vo.getTimestamp() + "," + vo.getIp() + "," + vo.getUri() + "," + vo.getUid());
	}*/

	// helpers
	private String GenerateTimestamp() {
		return (new Date()).toString();
	}
	private String GenerateIp() {
		return (rndDecByte()+"."+rndDecByte()+"."+rndDecByte()+"."+rndDecByte());
	}
	private String GenerateUri() {
		return ("http://bdelab.hska.de/pageviews/");
	}
	private String GenerateUid() {
		return (UUID.randomUUID().toString());
	}

	private String rndDecByte() {
		return String.valueOf(ThreadLocalRandom.current().nextInt(0, 256));
	}




}
