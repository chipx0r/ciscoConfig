//<system.web>
//    <webServices>
//      <soapExtensionTypes>
//        <add type="YourAssembly.PrefixExtension,YourAssembly" priority="1"/>
//      </soapExtensionTypes>
//    </webServices>
//  </system.web>
//////////////////////
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.Services.Protocols;
using System.Xml;

namespace Prefix
{
    
    public class PrefixExtension : SoapExtension
    {
        // Fields
        private Stream newStream;
        private Stream oldStream;

        private void AddPrefix()
        {
            this.newStream.Position = 0L;
            this.newStream = this.ProcessXML(this.newStream);
            this.Copy(this.newStream, this.oldStream);

        }


        public MemoryStream ProcessXML(Stream streamToPrefix)
        {
            streamToPrefix.Position = 0L;
            XmlTextReader reader = new XmlTextReader(streamToPrefix);

            XmlWriterSettings settings = new XmlWriterSettings();
            
            // This is where the magic happens. I'm removing some of the default namespaces then adding soapenv instead of regular soap.
            // There are many other things you can do once you get the response into the xmldocument object.
            // After you are done it converts it back then writes it to the response.
            XmlDocument doc = new XmlDocument();
            doc.Load(reader);
            
            doc.DocumentElement.Prefix = "soapenv";
            doc.DocumentElement.RemoveAttribute("xmlns:soap");
            doc.DocumentElement.RemoveAttribute("xmlns:xsi");
            doc.DocumentElement.FirstChild.Prefix = "soapenv";




            XmlReader reader2 = new XmlNodeReader(doc);
            settings.Encoding = Encoding.UTF8;
            MemoryStream outStream = new MemoryStream();
            using (XmlWriter writer = XmlWriter.Create(outStream, settings))
            {
                do
                {
                    writer.WriteNode(reader2, true);
                }
                while (reader2.Read());
                writer.Flush();
            }
            outStream.Seek(0, SeekOrigin.Begin);
            return outStream;
        }

        public override void ProcessMessage(SoapMessage message)
        {
            switch (message.Stage)
            {
                case SoapMessageStage.BeforeSerialize:
                case SoapMessageStage.AfterDeserialize:
                    return;

                case SoapMessageStage.AfterSerialize:
                    this.AddPrefix();
                    return;
                case SoapMessageStage.BeforeDeserialize:
                    this.GetReady();
                    return;
            }
            throw new Exception("invalid stage");
        }

        public override Stream ChainStream(Stream stream)
        {
            this.oldStream = stream;
            this.newStream = new MemoryStream();
            return this.newStream;
        }

        private void GetReady()
        {
            this.Copy(this.oldStream, this.newStream);
            this.newStream.Position = 0L;
        }

        private void Copy(Stream from, Stream to)
        {
            TextReader reader = new StreamReader(from);
            TextWriter writer = new StreamWriter(to);
            writer.WriteLine(reader.ReadToEnd());
            writer.Flush();
        }

        public override object GetInitializer(Type t)
        {
            return typeof(PrefixExtension);
        }

        public override object GetInitializer(LogicalMethodInfo methodInfo, SoapExtensionAttribute attribute)
        {
            return attribute;
        }

        public override void Initialize(object initializer)
        {
            //You'd usually get the attribute here and pull whatever you need off it.
            PrefixAttribute attr = initializer as PrefixAttribute;
        }

        [AttributeUsage(AttributeTargets.Method)]
        public class PrefixAttribute : SoapExtensionAttribute
        {
            // Fields
            private int priority;

            // Properties
            public override Type ExtensionType
            {
                get { return typeof(PrefixExtension); }
            }

            public override int Priority
            {
                get { return this.priority; }
                set { this.priority = value; }
            }
        }
    }
}
