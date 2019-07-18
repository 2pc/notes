注解Service,没有指定名字
```
@Service
public class SparkApplicationServiceImpl implements SparkApplicationService {}
```
生成名字规则:
1，如果Annotation设置了value，则从value中获取
2，如果没有设置则自动生成beanname

```
public class AnnotationBeanNameGenerator implements BeanNameGenerator {

	private static final String COMPONENT_ANNOTATION_CLASSNAME = "org.springframework.stereotype.Component";


	@Override
	public String generateBeanName(BeanDefinition definition, BeanDefinitionRegistry registry) {
		if (definition instanceof AnnotatedBeanDefinition) {
			String beanName = determineBeanNameFromAnnotation((AnnotatedBeanDefinition) definition);
			if (StringUtils.hasText(beanName)) {
				// Explicit bean name found.
				return beanName;
			}
		}
		// Fallback: generate a unique default bean name.
		return buildDefaultBeanName(definition, registry);
	}
```
设置了beanname,
```
1，如果类第一个第二个字母都是大小，则直接使用classname作为beanname
2，否则将第一个字母改成小写后作为beanname
```

```
	protected String determineBeanNameFromAnnotation(AnnotatedBeanDefinition annotatedDef) {
		AnnotationMetadata amd = annotatedDef.getMetadata();
		Set<String> types = amd.getAnnotationTypes();
		String beanName = null;
		for (String type : types) {
			AnnotationAttributes attributes = AnnotationConfigUtils.attributesFor(amd, type);
			if (isStereotypeWithNameValue(type, amd.getMetaAnnotationTypes(type), attributes)) {
				Object value = attributes.get("value");
				if (value instanceof String) {
					String strVal = (String) value;
					if (StringUtils.hasLength(strVal)) {
						if (beanName != null && !strVal.equals(beanName)) {
							throw new IllegalStateException("Stereotype annotations suggest inconsistent " +
									"component names: '" + beanName + "' versus '" + strVal + "'");
						}
						beanName = strVal;
					}
				}
			}
		}
		return beanName;
	}
```

没有设置，自动生成
```	
	protected String buildDefaultBeanName(BeanDefinition definition, BeanDefinitionRegistry registry) {
		return buildDefaultBeanName(definition);
	}
  	protected String buildDefaultBeanName(BeanDefinition definition) {
		String shortClassName = ClassUtils.getShortName(definition.getBeanClassName());
		return Introspector.decapitalize(shortClassName);
	}
  
  public static String decapitalize(String name) {
      if (name == null || name.length() == 0) {
          return name;
      }
      if (name.length() > 1 && Character.isUpperCase(name.charAt(1)) &&
                      Character.isUpperCase(name.charAt(0))){
          return name;
      }
      char chars[] = name.toCharArray();
      chars[0] = Character.toLowerCase(chars[0]);
      return new String(chars);
  }

```
